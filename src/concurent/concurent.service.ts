import { ConflictException, Injectable ,NotFoundException} from '@nestjs/common';
import { AjouterConcurentDto } from './dto/ajouterConcurent.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Concurent } from './schema/concurent.schema';
import { Model } from 'mongoose';
import { Produit, ProduitDocument } from 'src/produit/schema/produit.schema';
import { AjouterProduitDto } from './dto/ajouterProduit.dto';
import { Types } from 'mongoose'; // Import this to handle ObjectId
import { ObjectId } from 'mongoose'; // Ensure you import ObjectId


@Injectable()
export class ConcurentService {

  constructor(
    @InjectModel(Concurent.name)
    @InjectModel(Concurent.name) private readonly concurentModel: Model<Concurent>,
    @InjectModel(Produit.name) private readonly produitModel: Model<ProduitDocument>,

  ) {}

  async create(ajouterConcurentDto: AjouterConcurentDto): Promise<{ concurent }> {
    const { nom, abreviation } = ajouterConcurentDto

    const existingConcurent = await this.concurentModel.findOne({ nom });
    if (existingConcurent) {
      throw new ConflictException('Concurent existe déjà');
    }

    const concurent = await this.concurentModel.create({
      nom,
      abreviation
    })

    return { concurent }
  }

  async findAll(): Promise<{ concurent}> {
    const concurent = await this.concurentModel.find();
    return {  concurent };
  }

  remove(id: number) {
    return //This action removes a #${id} concurent;
  }


  async addProduit(id: string, ajouterProduitDto: AjouterProduitDto): Promise<{ message: string }> {
    const concurent = await this.concurentModel.findById(id);
    if (!concurent) {
      throw new NotFoundException('Concurent not found');
    }
  
    const produit = await this.produitModel.create({
      ...ajouterProduitDto,
      concurent: id, // Associate the produit with the concurent
    });
  
    // Cast produit._id to Types.ObjectId
    concurent.produits.push(produit._id as Types.ObjectId);
    await concurent.save();
  
    return { message: 'Produit added successfully' };
  }

  async getProduits(id: string) {
    const concurent = await this.concurentModel.findById(id).populate('produits');
    if (!concurent) {
      throw new NotFoundException('Concurent not found');
    }

    return concurent.produits;
  }

  async findByName(name: string): Promise<Concurent | null> {
    return this.concurentModel.findOne({ nom: name }).exec();
  }

  async findById(id: string): Promise<Concurent> {
    const concurent = await this.concurentModel.findById(id).exec();
    if (!concurent) {
      throw new NotFoundException(`Concurent with ID '${id}' not found`);
    }
    return concurent;
  }
}