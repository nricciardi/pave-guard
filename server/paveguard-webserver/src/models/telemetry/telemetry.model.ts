import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ discriminatorKey: 'type' })
export class Telemetry extends Document {

  @Prop({ required: true })
  deviceId: string;

  @Prop({ required: true })
  timestamp: string;
}

export const TelemetrySchema = SchemaFactory.createForClass(Telemetry);
