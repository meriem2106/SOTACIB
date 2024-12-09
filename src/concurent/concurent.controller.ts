import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { ConcurentService } from './concurent.service';
import { AjouterConcurentDto } from './dto/ajouterConcurent.dto';
import { AjouterProduitDto } from 'src/produit/dto/ajouterProduit.dto';


@Controller('concurent')
export class ConcurentController {
  constructor(private readonly concurentService: ConcurentService) {}

  @Post('/ajouterConcurent')
  create(@Body() ajouterConcurentDto: AjouterConcurentDto): Promise<{ concurent }> {
    return this.concurentService.create(ajouterConcurentDto);
  }

  @Get('/fetchConcurent')
  findAll(): Promise<{ concurent }> {
    return this.concurentService.findAll();
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.concurentService.remove(+id);
  }

  @Post(':id/produits') // Define the route for adding a product
  async addProduit(
    @Param('id') id: string, // Get the `id` of the concurent from the route
    @Body() ajouterProduitDto: AjouterProduitDto // Validate the body using DTO
  ): Promise<{ message: string }> {
    return this.concurentService.addProduit(id, ajouterProduitDto); // Call the service
  }

  @Get(':id/produits')
  async getProduits(@Param('id') id: string) {
    return this.concurentService.getProduits(id);
  }
}