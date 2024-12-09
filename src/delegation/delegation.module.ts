import { Module } from '@nestjs/common';
import { DelegationService } from './delegation.service';
import { DelegationController } from './delegation.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { Gouvernorat, GouvernoratSchema } from '@/gouvernorat/schema/gouvernorat.schema';
import { DelegationSchema } from './schema/delegation.schema';

@Module({
  imports:[MongooseModule.forFeature([
    {
     name: 'Delegation',
     schema: DelegationSchema
    },
    { name: Gouvernorat.name, schema: GouvernoratSchema },
  ])],
  controllers: [DelegationController],
  providers: [DelegationService],
})
export class DelegationModule {}