import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ITelemetry, Telemetry } from './telemetry.model';




@Schema()
export class HumidityTelemetry implements ITelemetry {
  deviceId: string;
  timestamp: number;
  kind: string;

  @Prop({ required: true })
  humidity: number;
}

export const HumidityTelemetrySchema = SchemaFactory.createForClass(HumidityTelemetry);
