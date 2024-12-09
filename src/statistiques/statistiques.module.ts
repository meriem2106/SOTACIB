import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { StatistiquesController } from './statistiques.controller';
import { StatistiquesService } from './statistiques.service';
import { Visite, VisiteSchema } from '../visite/schemas/visite.schema';
import { Produit, ProduitSchema } from '../produit/schema/produit.schema';
import { Client, ClientSchema } from '../client/schema/client.schema';
import { GouvernoratModule } from '../gouvernorat/gouvernorat.module'; // Import GouvernoratModule
import { ConcurentModule } from '../concurent/concurent.module'; // Import ConcurentModule

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Visite.name, schema: VisiteSchema },
      { name: Produit.name, schema: ProduitSchema },
      { name: Client.name, schema: ClientSchema },
    ]),
    GouvernoratModule,ConcurentModule,
  ],
  controllers: [StatistiquesController],
  providers: [StatistiquesService],
})
export class StatistiquesModule {}