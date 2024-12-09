import { BadRequestException, ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { AjouterClientDto } from './dto/ajouterClient.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Client } from './schema/client.schema';
import { Model, Types } from 'mongoose';
import { Gouvernorat } from '../gouvernorat/schema/gouvernorat.schema';
import { Delegation } from '@/delegation/schema/delegation.schema';
import { Concurent } from '@/concurent/schema/concurent.schema';
import { Produit } from '@/produit/schema/produit.schema';
import { Visite } from 'src/visite/schemas/visite.schema'
import axios from 'axios';
@Injectable()
export class ClientService {

  constructor(
    @InjectModel(Visite.name) private readonly visiteModel: Model<Visite>, // Ensure VisiteModel is injected

    @InjectModel(Client.name) private clientModel: Model<Client>,
    @InjectModel(Gouvernorat.name) private gouvernoratModel: Model<Gouvernorat>,
    @InjectModel(Delegation.name) private delegationModel: Model<Delegation>,
    @InjectModel(Concurent.name) private concurentModel: Model<Concurent>,
    @InjectModel(Produit.name) private produitModel: Model<Produit>,
  ) { }

  async create(ajouterClientDto: AjouterClientDto): Promise<{ client }> {
    const {
      responsable,
      clientNom,
      clientType,
      email,
      telephone,
      address,
      gouvernoratNom,
      delegationNom,
      produits = [], // Default to an empty array if not provided
    } = ajouterClientDto;
  
    const validatedProduits = [];
    for (const produit of produits) {
      const concurent = await this.concurentModel.findById(produit.concurentId);
      if (!concurent) throw new NotFoundException('Concurent not found');
  
      const produitEntity = await this.produitModel.findById(produit.produitId);
      if (!produitEntity) throw new NotFoundException('Produit not found');
  
      validatedProduits.push({
        concurent: produit.concurentId,
        produit: produit.produitId,
        prix: produit.prix,
      });
    }
  
    const client = await this.clientModel.create({
      responsable,
      clientNom,
      clientType,
      email,
      telephone,
      address,
      gouvernoratNom,
      delegationNom,
      produits: validatedProduits, // Store validated produits
    });
  
    return { client };
  }
  
  async findById(clientId: string): Promise<any> {
    if (!Types.ObjectId.isValid(clientId)) {
      throw new BadRequestException('Invalid ObjectId');
    }
  
    const client = await this.clientModel.findById(clientId).exec();
  
    if (!client) {
      throw new NotFoundException('Client not found');
    }
  
    return client;
  }
  

  async findAll(): Promise<{ client: any[] }> {
    const clients = await this.clientModel.find().exec();
    
    const clientsWithCoordinates = await Promise.all(
      clients.map(async (client) => {
        if (client.address) {
          const encodedAddress = encodeURIComponent(client.address);
          const geocodeUrl = `https://nominatim.openstreetmap.org/search?q=${encodedAddress}&format=json&addressdetails=1&limit=1`;
          try {
            const response = await axios.get(geocodeUrl);
            if (response.data && response.data.length > 0) {
              const { lat, lon } = response.data[0];
              return { ...client.toObject(), latitude: parseFloat(lat), longitude: parseFloat(lon) };
            }
          } catch (error) {
            console.error(`Failed to geocode address for client ${client._id}: ${error}`);
          }
        }
        return { ...client.toObject(), latitude: null, longitude: null };
      })
    );
  
    return { client: clientsWithCoordinates };
  }

  findOne(id: number) {
    return //This action returns a #${id} client;
  }

  update(id: number, updateClientDto: AjouterClientDto) {
    return //This action updates a #${id} client;
  }

  async remove(id: string): Promise<any> {
    try {
      const result = await this.clientModel.findByIdAndDelete(id); // Assuming `clientModel` is your Mongoose model
      if (!result) {
        throw new NotFoundException(`Client with ID ${id} not found`);
      }
      return { message: `Client with ID ${id} successfully deleted` };
    } catch (error) {
      throw new BadRequestException(`Failed to delete client: ${error}`);
    }
  }
  
  
}
