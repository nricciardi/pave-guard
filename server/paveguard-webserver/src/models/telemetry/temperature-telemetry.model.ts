// src/telemetry/temperature-telemetry.model.ts
import { Telemetry, TelemetrySchema } from './telemetry.model';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';


export const TEMPERATURE_TELEMETRY_TYPE = "TemperatureTelemetry";


@Schema()
export class TemperatureTelemetry extends Telemetry {
  @Prop({ required: true })
  temperature: number;
}

export const TemperatureTelemetryModel = TelemetrySchema.discriminator(
    TEMPERATURE_TELEMETRY_TYPE,
    SchemaFactory.createForClass(TemperatureTelemetry),
);
