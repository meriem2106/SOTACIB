import { Module } from '@nestjs/common';
import { ClientService } from './client.service';
import { ClientController } from './client.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { ClientSchema } from './schema/client.schema';
import { GouvernoratSchema } from '@/gouvernorat/schema/gouvernorat.schema';
import { DelegationSchema } from '@/delegation/schema/delegation.schema';
import { ConcurentSchema } from '@/concurent/schema/concurent.schema';
import { ProduitSchema } from '@/produit/schema/produit.schema';
import { VisiteModule } from '../visite/visite.module'; // Import VisiteModule


@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'Client', schema: ClientSchema },
      { name: 'Gouvernorat', schema: GouvernoratSchema },
      { name: 'Delegation', schema: DelegationSchema },
      { name: 'Concurent', schema: ConcurentSchema },
      { name: 'Produit', schema: ProduitSchema },
    ]),
    VisiteModule,
  ],  controllers: [ClientController],
  providers: [ClientService],
  exports: [MongooseModule],
})
export class ClientModule {}