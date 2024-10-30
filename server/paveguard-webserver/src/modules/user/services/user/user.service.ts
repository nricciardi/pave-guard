import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Document, Model } from 'mongoose';
import * as bcrypt from 'bcryptjs';
import { CreateUserDto } from '../../dto/create-user.dto';
import { User } from '../../models/user.model';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class UserService {
  constructor(
        private readonly configService: ConfigService,
        @InjectModel(User.name) private userModel: Model<User>
    ) {}

  async createUser(input: CreateUserDto): Promise<User> {

    const existingUser = await this.findByEmail(input.email);

    if (!!existingUser) {
      throw new ConflictException('Email already in use');
    }
    
    const hashedPassword = await bcrypt.hash(input.password, 10); // this.configService.get("SALT")

    input.password = hashedPassword;

    const newUser = new this.userModel(input);

    return newUser.save();
  }

  
  async findByEmail(email: string): Promise<User | null> {
    return this.userModel.findOne({ email });
  }

  
  async findById(userId: string): Promise<User> {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }
}
