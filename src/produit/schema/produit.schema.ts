import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { Concurent } from '../../concurent/schema/concurent.schema';

@Schema()
export class Produit {
  @Prop({ required: true })
  nom: string;

  @Prop({ required: true })
  prix: number;

  @Prop({ type: Types.ObjectId, ref: 'Concurent', required: true })
  concurent: Concurent;
  _id: Types.ObjectId;

}

export type ProduitDocument = Produit & Document;

export const ProduitSchema = SchemaFactory.createForClass(Produit);