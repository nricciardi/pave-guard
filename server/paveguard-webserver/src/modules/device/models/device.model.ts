import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from 'mongoose';


@Schema({ discriminatorKey: 'type', timestamps: {} })
export class Device extends Document {
  @Prop({ required: true, unique: true })
  serialNumber: string;
}

export const DeviceSchema = SchemaFactory.createForClass(Device);










