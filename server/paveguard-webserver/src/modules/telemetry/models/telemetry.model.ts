import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';


export interface ITelemetry {
  deviceId: string;
  
  timestamp: number;

  kind: string;
}


@Schema({ discriminatorKey: 'kind' })
export class Telemetry extends Document implements ITelemetry {

  @Prop({ required: true })
  deviceId: string;

  @Prop({ required: true })
  timestamp: number;

  @Prop({
    type: String,
    required: true,
    enum: [
      "TemperatureTelemetry",
      "HumidityTelemetry",
      "TrafficTelemetry"
    ]
  })
  kind: string;
}

export const TelemetrySchema = SchemaFactory.createForClass(Telemetry);
