import { Controller, Get, Post, Body, Param, Delete } from '@nestjs/common';
import { ProduitService } from './produit.service';
import { AjouterProduitDto } from './dto/ajouterProduit.dto';

@Controller('produit')
export class ProduitController {
  constructor(private readonly produitService: ProduitService) {}

  @Post('/ajouterProduit')
  async addProduit(@Body() ajouterProduitDto: AjouterProduitDto) {
    return this.produitService.create(ajouterProduitDto);
  }

  @Get('/fetchProduits')
  async findAll() {
    return this.produitService.findAll();
  }

  @Delete('/deleteProduit/:id')
  async remove(@Param('id') id: string) {
    return this.produitService.remove(id);
  }
}