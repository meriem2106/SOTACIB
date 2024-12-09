import { Module } from '@nestjs/common';
import { VisiteController } from './visite.controller';
import { VisiteService } from './visite.service';
import { MongooseModule } from '@nestjs/mongoose';
import { Visite, VisiteSchema } from './schemas/visite.schema';
import { ConcurentModule } from '../concurent/concurent.module'; // Import ConcurentModule
import { ProduitModule } from '../produit/produit.module'; // Import ProduitModule
import { Client, ClientSchema } from '../client/schema/client.schema';





@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Visite.name, schema: VisiteSchema },
      { name: Client.name, schema: ClientSchema }, // Import the Client schema
    ]),
    ConcurentModule,
    ProduitModule,
  ],
  controllers: [VisiteController],
  providers: [VisiteService],
  exports: [MongooseModule,VisiteService]
})
export class VisiteModule {}