import { Prop, SchemaFactory, Schema } from "@nestjs/mongoose";
import { Document } from "mongoose";



@Schema({ timestamps: {}})
export class User extends Document {
  @Prop({
    required: true,
    unique: true
  })
  email: string;

  @Prop({ required: true })
  password: string;

  @Prop({ required: true })
  userCode: string;

  @Prop({ required: true })
  firstName: string;

  @Prop({ required: true })
  lastName: string;

  @Prop({
    required: true, 
    default: false
  })
  admin: boolean;
}

export const UserSchema = SchemaFactory.createForClass(User);