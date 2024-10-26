import { ITelemetry, Telemetry, TelemetrySchema } from '../../model/telemetry-schema.model';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';


export const TEMPERATURE_TELEMETRY_TYPE = "TemperatureTelemetry";


@Schema()
export class TemperatureTelemetry implements ITelemetry {
  deviceId: string;
  timestamp: string;
  kind: string;

  @Prop({ required: true })
  temperature: number;
}

export const TemperatureTelemetrySchema = SchemaFactory.createForClass(TemperatureTelemetry);
