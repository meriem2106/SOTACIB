import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Gouvernorat, GouvernoratSchema } from './schema/gouvernorat.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Gouvernorat.name, schema: GouvernoratSchema },
    ]),
  ],
  exports: [
    MongooseModule.forFeature([
      { name: Gouvernorat.name, schema: GouvernoratSchema },
    ]),
  ], // Export the model to make it accessible in other modules
})
export class GouvernoratModule {}