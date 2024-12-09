
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Concurent, ConcurentSchema } from './schema/concurent.schema';
import { ConcurentService } from './concurent.service';
import { ProduitModule } from '../produit/produit.module'; // Import ProduitModule

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Concurent.name, schema: ConcurentSchema }]),
    ProduitModule, // Import ProduitModule to resolve ProduitModel
  ],
  providers: [ConcurentService],
  exports: [ConcurentService,MongooseModule],
})
export class ConcurentModule {}