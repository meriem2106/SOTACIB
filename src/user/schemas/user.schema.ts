import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type UserDocument = User & Document & { _id: string }; 

@Schema()
export class User {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  password: string;

  @Prop() 
  image?: string; 

  @Prop({ required: true, enum: ['admin', 'user'] })
  role: string;

  @Prop() // Add OTP field
  otp?: string;

  @Prop() // Add OTP expiry field
  otpExpiry?: Date;

}

export const UserSchema = SchemaFactory.createForClass(User);