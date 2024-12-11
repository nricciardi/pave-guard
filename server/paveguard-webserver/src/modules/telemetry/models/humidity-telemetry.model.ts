import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class HumidityTelemetry extends Document {

  @Prop({
    required: true,
    min: 0,
    max: 100
  })
  humidity: number;
}

export const HumidityTelemetrySchema = SchemaFactory.createForClass(HumidityTelemetry);
