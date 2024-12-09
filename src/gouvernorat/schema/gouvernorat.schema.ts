import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class Gouvernorat {

  @Prop({ required: true })
  nom: string;

}

export const GouvernoratSchema = SchemaFactory.createForClass(Gouvernorat);