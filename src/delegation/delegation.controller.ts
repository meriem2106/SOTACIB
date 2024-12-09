import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { DelegationService } from './delegation.service';
import { AjouterDelegationDto } from './dto/ajouterDelegation.dto';
import { Delegation } from './schema/delegation.schema';

@Controller('delegation')
export class DelegationController {
  constructor(private readonly delegationService: DelegationService) {}

  @Post('/ajouterDelegation')
  create(@Body() ajouterDelegationDto: AjouterDelegationDto): Promise<{ delegation }> {
    return this.delegationService.create(ajouterDelegationDto);
  }

  @Get('/fetchDelegation')
  findAll(): Promise<{ delegation }> {
    return this.delegationService.findAll();
  }

  @Get('fetchDelegationById/:gouvernoratId')
  async findByGouvernorat(@Param('gouvernoratId') gouvernoratId: string): Promise<{ delegation: Delegation[] }> {
    return this.delegationService.findByGouvernorat(gouvernoratId);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.delegationService.remove(+id);
  }
}