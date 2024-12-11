import { Prop, SchemaFactory, Schema } from "@nestjs/mongoose";
import { Document } from "mongoose";



@Schema()
export class PlanningCalendar extends Document {

    @Prop({
        required: true,
        default: Date.now()
    })
    date: Date;

    @Prop({
        required: false,
    })
    description?: string;

    @Prop({
        required: true,
        isInteger: true,
        min: 0,
        max: 100,
        default: 50
    })
    priority: number;

    
    @Prop({ required: true })
    road: string;

    @Prop({ required: true })
    city: string;

    @Prop({ required: false })
    county?: string;

    @Prop({ required: true })
    state: string;
}

export const PlanningCalendarSchema = SchemaFactory.createForClass(PlanningCalendar);