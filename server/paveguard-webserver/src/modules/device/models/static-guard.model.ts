import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Device } from "./device.model";


@Schema()
export class StaticGuard extends Device {
  @Prop({ required: true })
  road: string;

  @Prop({ required: true })
  city: string;

  @Prop({ required: false })
  county?: string;

  @Prop({ required: true })
  state: string;

  @Prop({ required: true })
  latitude: number;

  @Prop({ required: true })
  longitude: number;
}

export const StaticGuardSchema = SchemaFactory.createForClass(StaticGuard);