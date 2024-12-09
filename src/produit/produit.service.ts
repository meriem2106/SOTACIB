import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Produit } from 'src/produit/schema/produit.schema';
import { AjouterProduitDto } from './dto/ajouterProduit.dto';

@Injectable()
export class ProduitService {
  constructor(
    @InjectModel(Produit.name) private produitModel: Model<Produit>,
  ) {}

  async create(ajouterProduitDto: AjouterProduitDto): Promise<Produit> {
    const produit = new this.produitModel({
      ...ajouterProduitDto,
      concurent: new Types.ObjectId(ajouterProduitDto.concurentId),
    });
    return produit.save();
  }

  async findAll(): Promise<Produit[]> {
    return this.produitModel.find().populate('concurent').exec();
  }

  async remove(id: string): Promise<void> {
    const result = await this.produitModel.deleteOne({ _id: id }).exec();
    if (result.deletedCount === 0) {
      throw new NotFoundException(`Produit with ID "${id}" not found`);
    }
  }

  async findByName(nom: string): Promise<Produit | null> {
    return this.produitModel.findOne({ nom }).exec();
  }

  async findById(id: string): Promise<Produit> {
    const produit = await this.produitModel.findById(id).exec();
    if (!produit) {
      throw new NotFoundException(`Produit with ID '${id}' not found`);
    }
    return produit;
  }
}