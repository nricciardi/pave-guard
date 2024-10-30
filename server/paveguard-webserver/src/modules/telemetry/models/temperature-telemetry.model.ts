import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ITelemetry, Telemetry } from './telemetry.model';
import { Document } from 'mongoose';




@Schema()
export class TemperatureTelemetry extends Document implements ITelemetry {
  deviceId: string;
  timestamp: number;
  kind: string;

  @Prop({ required: true })
  temperature: number;
}

export const TemperatureTelemetrySchema = SchemaFactory.createForClass(TemperatureTelemetry);
