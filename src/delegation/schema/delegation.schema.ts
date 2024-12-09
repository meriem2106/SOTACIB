import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, SchemaTypes, Types } from 'mongoose';

@Schema()
export class Delegation {

  @Prop({ required: true })
  nom: string;

  @Prop({ type: SchemaTypes.ObjectId, ref: "Gouvernorat", required: true })
  gouvernorat: Types.ObjectId;

}

export const DelegationSchema = SchemaFactory.createForClass(Delegation); 