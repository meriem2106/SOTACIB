
// src/user/user.service.ts
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';

@Injectable()
export class UserService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async createUser(user: Partial<User>): Promise<User> {
    const newUser = new this.userModel(user);
    return newUser.save();
  }

  async findByEmail(email: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ email }).exec();
  }

  async findAll(): Promise<User[]> {
    return this.userModel.find().exec();
  }

  async saveOtp(userId: string, otp: string, expiry: Date): Promise<void> {
    await this.userModel.updateOne(
      { _id: userId },
      { otp, otpExpiry: expiry },
    );
  }

  async clearOtp(userId: string): Promise<void> {
    await this.userModel.updateOne(
      { _id: userId },
      { $unset: { otp: "", otpExpiry: "" } } // Remove OTP and expiry fields
    );
  }
  async findUserWithPendingOtp(): Promise<UserDocument | null> {
    return this.userModel.findOne({
      otp: { $exists: true },
      otpExpiry: { $gte: new Date() }, // Ensure OTP hasn't expired
    });
  }

    async updatePassword(userId: string, hashedPassword: string): Promise<void> {
    await this.userModel.updateOne({ _id: userId }, { password: hashedPassword });
  }

  async updateProfile(userId: string, updates: Partial<User>): Promise<User> {
    return this.userModel.findByIdAndUpdate(userId, updates, { new: true }).exec();
  }

  
}