import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, SchemaTypes, Types } from 'mongoose';
import * as mongoose from 'mongoose';
import { Client } from '@/client/schema/client.schema'; // Adjust the import path

@Schema()
export class Visite extends Document {
  @Prop({ required: true })
  date: Date;

  @Prop()
  observation?: string;

  @Prop()
  reclamation?: string;

  @Prop({ required: true })
  responsable: string;

  @Prop([
    {
      cimenterie: { type: mongoose.Schema.Types.ObjectId, ref: 'Concurent' }, // Reference to Concurent
      produits: [
        {
          produit: { type: mongoose.Schema.Types.ObjectId, ref: 'Produit' }, // Reference to Produit
          prix: { type: Number },
        },
      ],
    },
  ])
  cimenteries: Array<{
    cimenterie: Types.ObjectId; // Reference to Concurent
    produits: Array<{ produit: Types.ObjectId; prix: number }>; // Reference to Produit with price
  }>;


  @Prop({ type: SchemaTypes.ObjectId, ref: 'Client', required: true })
client: Types.ObjectId;


  @Prop()
  pieceJoint?: string;
}

export const VisiteSchema = SchemaFactory.createForClass(Visite);