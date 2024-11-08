import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';


@Schema()
export class RoadCrackTelemetry extends Document {

  @Prop({
    required: true,
    min: 0,
    max: 100
  })
  severity: number;
}

export const RoadCrackTelemetrySchema = SchemaFactory.createForClass(RoadCrackTelemetry);
