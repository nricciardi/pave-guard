import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class HumidityTelemetry extends Document {

  @Prop({ required: true })
  humidity: number;
}

export const HumidityTelemetrySchema = SchemaFactory.createForClass(HumidityTelemetry);
