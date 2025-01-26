import { Field, ArgsType } from '@nestjs/graphql';
import { IsBoolean, IsDate, IsNotEmpty, IsNumber, IsString, Max, Min } from 'class-validator';

@ArgsType()
export class UpdatePlanningDto {

    @Field({
        nullable: true
    })
    @IsDate()
    date?: Date;

    @Field({
        nullable: true
    })
    @IsString()
    description?: string;

    @Field({
        nullable: true
    })
    @IsString()
    road?: string;

    @Field({
        nullable: true
    })
    @IsString()
    city?: string;

    @Field({
        nullable: true
    })
    @IsString()
    county?: string;

    @Field({
        nullable: true
    })
    @IsString()
    state?: string;

    @Field({
        nullable: true
    })
    @IsBoolean()
    done?: boolean;
}
