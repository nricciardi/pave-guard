import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class RoadPotholeTelemetry extends Document {

  @Prop({
    required: true,
    min: 0,
    max: 100
  })
  severity: number;
}

export const RoadPotholeTelemetrySchema = SchemaFactory.createForClass(RoadPotholeTelemetry);
