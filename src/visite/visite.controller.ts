import { Controller, Get, Post, Body, Param, Delete } from '@nestjs/common';
import { VisiteService } from './visite.service';
import { AjouterVisiteDto } from './dto/ajouterVisite.dto';
import { Visite } from './schemas/visite.schema'; // Correct path for Visite schema

@Controller('visite')
export class VisiteController {
  constructor(private readonly visiteService: VisiteService) {}

  @Post('/ajouterVisite')
async createVisite(@Body() ajouterVisiteDto: AjouterVisiteDto): Promise<{ message: string }> {
  await this.visiteService.create(ajouterVisiteDto);
  return { message: 'Visite created successfully' };
}
@Get('/fetchVisites')
async getAllVisites(): Promise<Visite[]> {
  return this.visiteService.findAll();
}
  @Get()
  async findAll() {
    return this.visiteService.findAll();
  }

  @Get(':id')
  async findById(@Param('id') id: string) {
    return this.visiteService.findById(id);
  }

  @Delete(':id')
  async deleteById(@Param('id') id: string) {
    return this.visiteService.deleteById(id);
  }
  
}