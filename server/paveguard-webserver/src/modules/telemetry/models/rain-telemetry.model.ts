import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class RainTelemetry extends Document {

  @Prop({
    required: true,
    min: 0
  })
  mm: number;
}

export const RainTelemetrySchema = SchemaFactory.createForClass(RainTelemetry);
