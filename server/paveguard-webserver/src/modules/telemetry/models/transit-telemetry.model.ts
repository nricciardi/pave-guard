import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class TransitTelemetry extends Document {

    @Prop({ required: true })
    length: number;

    @Prop({ required: true })
    velocity: number;

    @Prop({ required: true })
    transitTime: number;
}

export const TransitTelemetrySchema = SchemaFactory.createForClass(TransitTelemetry);
