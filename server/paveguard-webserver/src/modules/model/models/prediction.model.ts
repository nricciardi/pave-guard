import { Prop, SchemaFactory, Schema } from "@nestjs/mongoose";
import { Document } from "mongoose";



@Schema()
export class Prediction extends Document {

    @Prop({
        required: true
    })
    updatedAt: Date;

    @Prop({
        required: true
    })
    crackSeverityPredictions: number[];

    @Prop({
        required: true
    })
    potholeSeverityPredictions: number[];

    @Prop({ required: true })
    road: string;

    @Prop({ required: true })
    city: string;

    @Prop({ required: false })
    county?: string;

    @Prop({ required: true })
    state: string;

}

export const PredictionSchema = SchemaFactory.createForClass(Prediction);