import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class TrafficTelemetry extends Document {
}

export const TrafficTelemetrySchema = SchemaFactory.createForClass(TrafficTelemetry);
