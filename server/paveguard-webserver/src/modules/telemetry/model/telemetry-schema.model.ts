import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { TemperatureTelemetry } from '../temperature-telemetry/models/temperature-telemetry-schema.model';


export interface ITelemetry {
  deviceId: string;
  timestamp: string;
  kind: string;
} 



@Schema({ discriminatorKey: 'kind' })
export class Telemetry extends Document implements ITelemetry {

  @Prop({ required: true })
  deviceId: string;

  @Prop({ required: true })
  timestamp: string;

  @Prop({
    type: String,
    required: true,
    enum: [
      TemperatureTelemetry.name
    ]
  })
  kind: string;
}

export const TelemetrySchema = SchemaFactory.createForClass(Telemetry);
