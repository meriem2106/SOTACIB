import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, SchemaTypes, Types } from 'mongoose';

@Schema()
export class Client {

  @Prop({ required: true })
  responsable: string;

  @Prop({ required: true })
  clientNom: string;

  @Prop({
    type: String,
    required: true,
    enum: ['G', 'D', 'NC'], // Allowed values
  })
  clientType: 'G' | 'D' | 'NC';

  @Prop({ required: true })
  email: string;

  @Prop({ required: true })
  telephone: number;

  @Prop({ required: true })
  address: string;

  @Prop({ required: true })
  gouvernoratNom: string;

  @Prop({ required: true })
  delegationNom: string;

  @Prop({
    type: [
      {
        concurent: { type: SchemaTypes.ObjectId, ref: 'Concurent', required: true },
        produit: { type: SchemaTypes.ObjectId, ref: 'Produit', required: true },
        prix: { type: Number, required: true },
      },
    ],
    required: true,
  })
  produits: {
    concurent: Types.ObjectId;
    produit: Types.ObjectId;
    prix: number;
  }[];

  @Prop({ type: [{ type: SchemaTypes.ObjectId, ref: 'Visite' }] })
  visites: Types.ObjectId[];

}

export const ClientSchema = SchemaFactory.createForClass(Client);

/*@Prop({ type: SchemaTypes.ObjectId, ref: 'Gouvernorat', required: true })
  gouvernorat: Types.ObjectId;

  @Prop({ type: SchemaTypes.ObjectId, ref: 'Delegation', required: true })
  delegation: Types.ObjectId;*/