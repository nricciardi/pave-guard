import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';




@Schema()
export class TransitTelemetry extends Document {

    @Prop({
        required: true,
        min: 0
    })
    length: number;

    @Prop({
        required: true,
        min: 0
    })
    velocity: number;

    @Prop({
        required: true,
        min: 0
    })
    transitTime: number;
}

export const TransitTelemetrySchema = SchemaFactory.createForClass(TransitTelemetry);
