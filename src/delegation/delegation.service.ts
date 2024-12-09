import { ConflictException, Injectable } from '@nestjs/common';
import { AjouterDelegationDto } from './dto/ajouterDelegation.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Delegation } from './schema/delegation.schema';
import { Gouvernorat } from '@/gouvernorat/schema/gouvernorat.schema';
import { Model } from 'mongoose';

@Injectable()
export class DelegationService {

  constructor(
    @InjectModel(Delegation.name)
    private delegationModel: Model<Delegation>,
    @InjectModel(Gouvernorat.name)
    private gouvernoratModel: Model<Gouvernorat>
  ) { }

  async create(ajouterDelegationDto: AjouterDelegationDto): Promise<{ delegation }> {
    const { nom, gouvernoratNom } = ajouterDelegationDto;
  
    // Find the Gouvernorat by name
    const gouvernorat = await this.gouvernoratModel.findOne({ nom: gouvernoratNom });
    if (!gouvernorat) {
      throw new ConflictException(`Gouvernorat with the name "${gouvernoratNom}" does not exist!`);
    }
  
    // Check if a delegation with the same name already exists
    const existingDelegation = await this.delegationModel.findOne({ nom });
    if (existingDelegation) {
      throw new ConflictException('Delegation with the same name already exists');
    }
  
    // Create and save the new Delegation
    const delegation = new this.delegationModel({
      nom,
      gouvernorat: gouvernorat._id,
    });
    await delegation.save();
  
    return { delegation };
  }

  async findAll(): Promise<{ delegation }> {
    const delegation = await this.delegationModel.find();
    return { delegation };
  }

  async findByGouvernorat(gouvernoratId?: string): Promise<{ delegation: Delegation[] }> {
    const query = gouvernoratId ? { gouvernorat: gouvernoratId } : {};
    const delegations = await this.delegationModel.find(query).exec();
    return { delegation: delegations };
  }

  remove(id: number) {
    return //This action removes a #${id} delegation;
  }
}