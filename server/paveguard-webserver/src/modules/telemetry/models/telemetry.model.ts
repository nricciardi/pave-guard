import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';


export interface ITelemetry {
  deviceId: string;
  
  timestamp: number;

  kind: string;
}


@Schema({ discriminatorKey: 'kind' })
export class Telemetry implements ITelemetry {

  @Prop({ required: true })
  deviceId: string;

  @Prop({ required: true })
  timestamp: number;

  @Prop({
    type: String,
    required: true,
    enum: [
      "TemperatureTelemetry",
      "HumidityTelemetry"
    ]
  })
  kind: string;
}

export const TelemetrySchema = SchemaFactory.createForClass(Telemetry);
