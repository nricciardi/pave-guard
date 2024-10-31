import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ITelemetry, Telemetry } from './telemetry.model';
import { Document } from 'mongoose';




@Schema()
export class TrafficTelemetry extends Document implements ITelemetry {
  deviceId: string;
  timestamp: number;
  kind: string;

  @Prop({ required: true })
  start: number
  
  @Prop({ required: false })
  level: number

  @Prop({ required: true })
  end: number
}

export const TrafficTelemetrySchema = SchemaFactory.createForClass(TrafficTelemetry);
