import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class TemperatureTelemetry extends Document {

  @Prop({ required: true })
  temperature: number;
}

export const TemperatureTelemetrySchema = SchemaFactory.createForClass(TemperatureTelemetry);
