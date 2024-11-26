import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class RainTelemetry extends Document {

  @Prop({ required: true })
  mm: number;
}

export const RainTelemetrySchema = SchemaFactory.createForClass(RainTelemetry);
