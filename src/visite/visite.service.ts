import { Injectable, NotFoundException ,InternalServerErrorException} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model,Types} from 'mongoose';
import { Visite } from './schemas/visite.schema';
import { AjouterVisiteDto } from './dto/ajouterVisite.dto';
import { ConcurentService } from '../concurent/concurent.service';
import { ProduitService } from '../produit/produit.service';
import { Client } from '../client/schema/client.schema';


@Injectable()
export class VisiteService {
  constructor(
    @InjectModel(Visite.name) private readonly visiteModel: Model<Visite>,
    @InjectModel(Client.name) private readonly clientModel: Model<Client>,
    private readonly concurentService: ConcurentService,
    private readonly produitService: ProduitService,
  ) {}

  async create(ajouterVisiteDto: AjouterVisiteDto): Promise<Visite> {
    console.log('Creating a new visit with DTO:', ajouterVisiteDto);
  
    const { cimenteries, client, ...rest } = ajouterVisiteDto;
  
    try {
      const formattedCimenteries = await Promise.all(
        cimenteries.map(async (c) => {
          const concurent = await this.concurentService.findById(c.cimenterie);
          if (!concurent) {
            throw new Error(`Concurent not found for ID: ${c.cimenterie}`);
          }
          console.log(`Found concurent: ${JSON.stringify(concurent)}`);
  
          const formattedProduits = await Promise.all(
            c.produits.map(async (p) => {
              const produit = await this.produitService.findById(p.produit);
              if (!produit) {
                throw new Error(`Produit not found for ID: ${p.produit}`);
              }
              console.log(`Found produit: ${JSON.stringify(produit)}`);
              return { produit: produit._id, prix: p.prix };
            }),
          );
  
          return { cimenterie: concurent._id, produits: formattedProduits };
        }),
      );
  
      const visite = new this.visiteModel({
        ...rest,
        client: client ? new Types.ObjectId(client) : undefined,
        cimenteries: formattedCimenteries,
      });
  
      const savedVisite = await visite.save();
      console.log('Saved visite:', savedVisite);
  
      if (client) {
        const updatedClient = await this.clientModel.findByIdAndUpdate(
          client,
          { $push: { visites: savedVisite._id } },
          { new: true, useFindAndModify: false }
        );
        console.log('Updated client with new visite:', updatedClient);
      }
  
      return savedVisite;
    } catch (error) {
      console.error('Error creating visite:', error);
      throw new InternalServerErrorException('Unable to create visite');
    }
  }
  

async findAll(): Promise<any[]> {
  const visites = await this.visiteModel
    .find()
    .populate('client', 'nom') // Ensure the `nom` field of `client` is loaded
    .exec();

  return visites.map((visite) => ({
    date: visite.date,
    observation: visite.observation,
    reclamation: visite.reclamation,
    responsable: visite.responsable,
    client: (visite.client as any)?.nom || null,
    pieceJoint: visite.pieceJoint,
    cimenteries: visite.cimenteries,
  }));
}

async findById(id: string): Promise<any> {
  const visite = await this.visiteModel
    .findById(id)
    .populate({
      path: 'client', 
      select: 'clientNom', 
    })
    .exec();

  if (!visite) {
    throw new NotFoundException('Visite not found');
  }

  return {
    date: visite.date,
    observation: visite.observation,
    reclamation: visite.reclamation,
    responsable: visite.responsable,
    client: visite.client ? visite.client['clientNom'] : null, // Safely access `clientNom`
    pieceJoint: visite.pieceJoint,
    cimenteries: visite.cimenteries,
  };
}

  async deleteById(id: string): Promise<void> {
    const result = await this.visiteModel.deleteOne({ _id: id }).exec();
    if (result.deletedCount === 0) {
      throw new NotFoundException('Visite not found');
    }
  }

  async findAllByClient(clientId: string): Promise<any[]> {
    const visites = await this.visiteModel
      .find({ client: clientId }) // Fetch visits where `client` matches the provided ID
      .populate({
        path: 'client',
        select: 'clientNom email telephone address', // Fetch only necessary fields of the client
      })
      .populate({
        path: 'cimenteries.cimenterie',
        select: 'nom abreviation', // Fetch details about the cement factory
      })
      .populate({
        path: 'cimenteries.produits.produit',
        select: 'nom prix', 
      })
      .exec();
  
    if (!visites || visites.length === 0) {
      throw new NotFoundException('No visites found for this client');
    }
  
    return visites.map((visite) => ({
      date: visite.date,
      observation: visite.observation,
      reclamation: visite.reclamation,
      responsable: visite.responsable,
      client: visite.client,
      pieceJoint: visite.pieceJoint,
      cimenteries: visite.cimenteries.map((cimenterie) => ({
        cimenterie: cimenterie.cimenterie,
        produits: cimenterie.produits.map((produit) => ({
          produit: produit.produit,
          prix: produit.prix,
        })),
      })),
    }));
  }
}