import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema()
export class Concurent extends Document {
  @Prop({ required: true })
  nom: string;

  @Prop({ required: true })
  abreviation: string;

  @Prop({ type: [{ type: Types.ObjectId, ref: 'Produit' }] }) // Use Types.ObjectId explicitly
  produits: Types.ObjectId[];
}

export const ConcurentSchema = SchemaFactory.createForClass(Concurent);