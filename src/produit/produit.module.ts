// src/produit/produit.module.ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ProduitService } from './produit.service';
import { ProduitController } from './produit.controller';
import { Produit, ProduitSchema } from './schema/produit.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Produit.name, schema: ProduitSchema }]),
  ],
  controllers: [ProduitController],
  providers: [ProduitService],
  exports: [ProduitService,MongooseModule], // Export the service if needed in other modules
})
export class ProduitModule {}