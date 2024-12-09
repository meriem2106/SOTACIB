import { ConflictException, Injectable } from '@nestjs/common';
import { AjouterGouvernoratDto } from './dto/ajouterGouvernorat.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Gouvernorat } from './schema/gouvernorat.schema';
import { Model } from 'mongoose';

@Injectable()
export class GouvernoratService {
  
  constructor(
    @InjectModel(Gouvernorat.name)
    private gouvernoratModel: Model<Gouvernorat>
  ) { }

  async create(ajouterGouvernoratDto: AjouterGouvernoratDto): Promise<{ gouvernorat }> {
    const { nom } = ajouterGouvernoratDto

    const existingGouvernorat = await this.gouvernoratModel.findOne({ nom });
    if (existingGouvernorat) {
      throw new ConflictException('Gouvernorat existe déjà');
    }

    const gouvernorat = await this.gouvernoratModel.create({
      nom
    })

    return { gouvernorat }
  }

  async findAll(): Promise<{ gouvernorat}> {
    const gouvernorat = await this.gouvernoratModel.find();
    return {  gouvernorat };
  }

}