import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';


@Schema()
export class FailTelemetry extends Document {

  @Prop({ required: true })
  code: string;

  @Prop({ required: false })
  message: string;
}

export const FailTelemetrySchema = SchemaFactory.createForClass(FailTelemetry);
