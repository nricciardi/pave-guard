import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ITelemetry, Telemetry } from './telemetry.model';




@Schema()
export class TemperatureTelemetry implements ITelemetry {
  deviceId: string;
  timestamp: number;
  kind: string;

  @Prop({ required: true })
  temperature: number;
}

export const TemperatureTelemetrySchema = SchemaFactory.createForClass(TemperatureTelemetry);
