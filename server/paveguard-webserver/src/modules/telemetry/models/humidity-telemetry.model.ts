import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ITelemetry, Telemetry } from './telemetry.model';
import { Document } from 'mongoose';




@Schema()
export class HumidityTelemetry extends Document implements ITelemetry {
  deviceId: string;
  timestamp: number;
  kind: string;

  @Prop({ required: true })
  humidity: number;
}

export const HumidityTelemetrySchema = SchemaFactory.createForClass(HumidityTelemetry);
