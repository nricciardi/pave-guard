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

  @Prop({
    required: true,
    min: -90,
    max: 90,
  })
  latitude: number;

  @Prop({
    required: true,
    min: -180,
    max: 180,
  })
  longitude: number;
}

export const StaticGuardSchema = SchemaFactory.createForClass(StaticGuard);