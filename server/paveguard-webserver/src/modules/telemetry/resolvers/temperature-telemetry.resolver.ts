import { Resolver, Query, Args, Mutation, Field, ObjectType, ArgsType } from '@nestjs/graphql';
import { TemperatureTelemetryService } from '../services/temperature-telemetry/temperature-telemetry.service';
import { TelemetryCreateMutation, TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { IsNumber, IsNotEmpty } from 'class-validator';


@ObjectType()
export class TemperatureTelemetryQuery extends TelemetryQuery {

  @Field()
  temperature: number;
}

@ArgsType()
export class TemperatureTelemetryCreateMutation extends TelemetryCreateMutation {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  temperature: number;
}


@Resolver(() => TemperatureTelemetryQuery)
export class TemperatureTelemetryResolver {
  constructor(
    private readonly temperatureTelemetryService: TemperatureTelemetryService,
  ) {}

  @Query(() => [TemperatureTelemetryQuery])
  @UseGuards(AdminGuard)
  async temperatureTelemetries() {
    return this.temperatureTelemetryService.findAll();
  }

  @Mutation(() => TemperatureTelemetryQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createTemperatureTelemetry(
    @Args() input: TemperatureTelemetryCreateMutation,
  ) {
    
    return this.temperatureTelemetryService.create(input);
  }
}

